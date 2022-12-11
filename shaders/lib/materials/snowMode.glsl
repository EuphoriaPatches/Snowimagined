float snowVariable = 0.0;
float upGradient = abs(clamp(dot(normal, upVec), 0.0, 1.0));
vec3 desaturateColor = color.rgb;
float snowDesaturation = COLOR_DESATURATION;

// Color Desaturation
if (COLOR_DESATURATION > 0.0) {
	if (isEyeInWater != 0) snowDesaturation = COLOR_DESATURATION * 0.5;
	desaturateColor = clamp(mix(color.rgb, color.rgb * (GetLuminance(color.rgb) / color.rgb), clamp01(snowDesaturation - lmCoord.x)), 0.0, 1.0);
}

vec3 winterColor = desaturateColor;
float winterAlpha = color.a;

// specific materials
if (mat == 10000 || mat == 10004 || mat == 10020 || mat == 10348 || mat == 10628 || mat == 10472) snowVariable = mix(1.0, 0.0, (color.r + color.g + color.b) * 0.3); // vegetation check
if (mat == 10492 || mat == 10006) snowVariable = mix(1.0, 0.0, (color.r + color.g + color.b) * 0.1 - 1.0); // fungus and mushroom
if (mat == 10005 && color.g * 1.5 > color.r + color.b) snowVariable = mix(1.0, 0.0, 1 / (color.g * color.g) * 0.01); //wither rose
if (mat == 10008) snowVariable = mix(1.0, 0.0, 1 / (color.g * color.g) * 0.033); //leaves
if (mat == 10016 || mat == 10060 || mat == 10017) snowVariable = mix(1.0, 0.0, 1 / (color.g * color.g) * 0.09); // sugar cane, bamboo, propagule
if (mat == 10012) snowVariable = mix(1.0, 0.0, 1 / (color.g * color.g) * 0.04); // vine
if ((mat == 10132 && glColor.b < 0.999 && upGradient < 0.99) || (mat == 10129 && color.b + color.g < color.r * 2.0 && color.b > 0.3 && color.g < 0.45 && upGradient < 0.99) || (mat == 10130 && color.r > 0.52 && color.b < 0.30 && color.g > 0.41 && color.g + color.b * 0.95 > color.r * 1.2 && upGradient < 0.99)) snowVariable = mix(0.0, 1.0, pow(midUV.y, 3.0)); // add to the side of grass, mycelium, path blocks; in that order. Use midUV to increase transparency the the further down the block it goes
if (mat == 10132 && glColor.b < 0.999) snowVariable += abs(color.g - color.g * 0.5); // mute the grass colors a bit

snowVariable += upGradient; // normal check for top surfaces

if (snowVariable > 0.001) {
	vec3 snowColor = vec3(0.5843, 0.6314, 0.6471);
	
	// snow noise
	vec3 worldPos = playerPos + cameraPosition;

	float snowNoise = float(hash33(floor(mod(worldPos, vec3(100.0)) * SNOW_SIZE + 0.03) * SNOW_SIZE)) * 0.25; // pixel-locked procedural noise

	snowColor *= 1.25;
	snowColor += 0.13 * snowNoise * SNOW_NOISE_INTENSITY; // make the noise less noticeable & configurable with option

	float snowRemoveNoise1 = 1.0 - texture2D(noisetex, 0.0005 * (worldPos.xz + worldPos.y)).r;
	float snowRemoveNoise2 = 1.0 - texture2D(noisetex, 0.005 * (worldPos.xz + worldPos.y)).r;
	float snowRemoveNoise3 = texture2D(noisetex, 0.02 * (worldPos.xz + worldPos.y)).r;
	snowVariable *= clamp(2.0 * snowRemoveNoise1 + 0.70 * snowRemoveNoise2 + 0.2 * snowRemoveNoise3, 0.0, 1.0);

	// light check
	snowVariable = clamp(snowVariable, 0.0, 1.0); // to prevent stuff breaking, like the fucking bamboo sapling!!!!
    snowVariable *= (1.0 - pow(lmCoord.x, 2.5) * 4.3) * pow(lmCoord.y, 14.0); // first part to turn off at light sources, second part to turn off if under blocks
	snowVariable = clamp(snowVariable, 0.0, SNOW_TRANSPARENCY * 0.1 + 0.8); // to prevent artifacts near light sources

	//gbuffer specific features
		#if defined GBUFFERS_TERRAIN || defined GBUFFERS_BLOCK || defined GBUFFERS_WATER
			#ifdef IPBR
				smoothnessG = mix(smoothnessG,(1.0 - pow(color.g, 64.0) * 0.3) * 0.3, snowVariable); // values taken from snow.glsl
				highlightMult = mix(highlightMult, 2.0, snowVariable);
			#endif
		#endif

		#ifdef GBUFFERS_TERRAIN
			if (dot(normal, upVec) > 0.99) emission *= snowEmission;
			smoothnessD = mix(smoothnessD, smoothnessG, snowVariable);
		#endif

		#ifdef GBUFFERS_WATER
			if (dot(normal, upVec) > 0.99) snowTransparentOverwrite = snowAlpha;
			fresnel = mix(fresnel, 0.01, snowVariable * snowFresnelMult);
		#endif

	// final mix
	winterColor = mix(desaturateColor, snowColor, snowVariable * snowIntensity);
	winterAlpha = mix(color.a, 1.0, clamp(snowTransparentOverwrite * snowVariable, 0.0, 1.0));
}
#ifdef GBUFFERS_ENTITIES
color.rgb = desaturateColor;
#else
color.rgb = winterColor;
color.a = winterAlpha;
#endif