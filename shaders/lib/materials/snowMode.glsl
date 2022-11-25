float snowVariable = 0.0;
float upGradient = abs(clamp(dot(normal, upVec), 0.0, 1.0));

// Color Desaturation
#if COLOR_DESATURATION > 0.0
	color.rgb = clamp(mix(color.rgb, color.rgb * (GetLuminance(color.rgb) / color.rgb), clamp01(COLOR_DESATURATION - lmCoord.x)), 0.0, 1.0);
#endif

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

if (snowVariable > 0.0) {
	vec3 snowColor = vec3(0.5843, 0.6314, 0.6471);
	
	// snow noise
	vec3 worldPos = playerPos + cameraPosition;
	#if SNOW_NOISE_TYPE == 0
		// /*Please don't remove.*/ float snowNoise = texture2D(noisetex, floor(worldPos.xz * SNOW_SIZE + 0.03 + floor(worldPos.y * SNOW_SIZE + 0.01)) / SNOW_SIZE - normalize(cameraPosition.xz) - normalize(cameraPosition.y) + 0.5 / SNOW_SIZE).r; // pixel-locked noise based on the noise texture.
		float snowNoise = float(hash33(floor(mod(worldPos, vec3(100.0)) * SNOW_SIZE + 0.03) * SNOW_SIZE)) * 0.25; // pixel-locked procedural noise
		snowColor *= 1.1;
	#else
		float snowNoise = texture2D(noisetex, signMidCoordPos * 0.008 * SNOW_SIZE).r; // non-pixel-locked noise
	#endif
	snowColor += 0.13 * snowNoise * SNOW_NOISE_INTENSITY; // make the noise less noticeable & configurable with option

	float snowRemoveNoise1 = 1.0 - texture2D(noisetex, 0.0005 * (worldPos.xz + worldPos.y)).r;
	float snowRemoveNoise2 = 1.0 - texture2D(noisetex, 0.005 * (worldPos.xz + worldPos.y)).r;
	float snowRemoveNoise3 = texture2D(noisetex, 0.02 * (worldPos.xz + worldPos.y)).r;
	snowVariable *= clamp(2.0 * snowRemoveNoise1 + 0.70 * snowRemoveNoise2 + 0.2 * snowRemoveNoise3, 0.0, 1.0);

	// light check
	snowVariable = clamp(snowVariable, 0.0, 1.0); // to prevent stuff breaking, like the fucking bamboo sapling!!!!
    snowVariable *= (1.0 - pow(lmCoord.x, 2.5) * 4.3) * pow(lmCoord.y, 14.0); // first part to turn off at light sources, second part to turn off if under blocks
	snowVariable = clamp(snowVariable, 0.0, SNOW_TRANSPARENCY * 0.1 + 0.8); // to prevent artifacts near light sources

	// final mix
	color.rgb = mix(color.rgb, snowColor, snowVariable * snowIntensity);
	color.a = mix(color.a, 1.0, snowTransparentOverwrite * snowVariable);

	#ifdef IPBR
		smoothnessG = mix(smoothnessG,(1.0 - pow(color.g, 64.0) * 0.3) * 0.3, snowVariable); // values taken from snow.glsl
		highlightMult = mix(highlightMult, 2.0, snowVariable);
	#endif
}
