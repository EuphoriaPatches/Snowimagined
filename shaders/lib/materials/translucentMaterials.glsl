if (mat < 31008) {
    if (mat < 30016) {
        if (mat < 30008) {
            if (mat == 30000) { // Stained Glass
                #include "/lib/materials/specificMaterials/translucents/stainedGlass.glsl"
                if (dot(normal, upVec) > 0.99) snowTransparentOverwrite = 0.95;
            } else /*if (mat == 30004)*/ { // Stained Glass Pane
                #include "/lib/materials/specificMaterials/translucents/stainedGlass.glsl"
                noSmoothLighting = true;
                if (dot(normal, upVec) > 0.99) snowTransparentOverwrite = 0.95;
            }
        } else {
            if (mat == 30008) { // Tinted Glass
                color.a = pow(color.a, 1.0 - sqrt1(fresnel) * 0.65);
                fresnel *= 0.75;
                if (dot(normal, upVec) > 0.99) snowTransparentOverwrite = 0.85;
            } else /*if (mat == 30012)*/ { // Slime Block
                translucentMultAlreadyCalculated = true;
                fresnel *= 0.25;
                translucentMult = vec4(pow2(color.rgb) * 0.2, 1.0);

                smoothnessG = color.g * 0.5;
                highlightMult = 3.5;
                if (dot(normal, upVec) > 0.99) snowTransparentOverwrite = 0.8;
            }
        }
    } else {
        if (mat < 31000) {
            if (mat == 30016) { // Honey Block
                translucentMultAlreadyCalculated = true;
                fresnel *= 0.25;
                translucentMult = vec4(pow2(color.rgb) * 0.2, 1.0);

                smoothnessG = color.r * 0.7;
                highlightMult = 3.5;
                if (dot(normal, upVec) > 0.99) snowTransparentOverwrite = 0.6;
            } else /*if (mat == 30020)*/ { // Nether Portal
                #ifdef FANCY_NETHERPORTAL
                    #include "/lib/materials/specificMaterials/translucents/netherPortal.glsl"
                #endif
            }
        } else {
            if (mat == 31000) { // Water
                #include "/lib/materials/specificMaterials/translucents/water.glsl"
                snowIntensity = 0.0;
                snowFresnelMult = 0.0;
            } else /*if (mat == 31004)*/ { // Ice
                smoothnessG = pow2(color.g) * color.g;
                highlightMult = pow2(min1(pow2(color.g) * 1.5)) * 3.5;

                fresnel *= 0.7;
                if (dot(normal, upVec) > 0.99) snowTransparentOverwrite = 0.75;
            }
        }
    }
} else {
    if (mat < 31024) {
        if (mat < 31016) {
            if (mat == 31008) { // Glass
                #include "/lib/materials/specificMaterials/translucents/glass.glsl"
                if (dot(normal, upVec) > 0.99) snowTransparentOverwrite = 0.6;
            } else /*if (mat == 31012)*/ { // Glass Pane
                if (color.a < 0.001 && abs(NdotU) > 0.95) discard; // Fixing artifacts on connected glass panes
                #include "/lib/materials/specificMaterials/translucents/glass.glsl"
                noSmoothLighting = true;
                if (dot(normal, upVec) > 0.99) snowTransparentOverwrite = 0.6;
            }
        } else {
            if (mat == 31016) { // Beacon
                translucentMultAlreadyCalculated = true;
                lmCoordM.x = 0.88;
                
                if (color.b > 0.5) {
                    if (color.g - color.b < 0.01 && color.g < 0.99) {
                        #include "/lib/materials/specificMaterials/translucents/glass.glsl"
                    } else { // Beacon:Center
                        lmCoordM = vec2(0.0);
                        noDirectionalShading = true;

                        float lColor = length(color.rgb);
                        vec3 baseColor = vec3(0.1, 1.0, 0.92);
                        if (lColor > 1.5)       color.rgb = baseColor + 0.2;
                        else if (lColor > 1.3)  color.rgb = baseColor + 0.1;
                        else if (lColor > 1.15) color.rgb = baseColor + 0.05;
                        else                    color.rgb = baseColor + 0.02;
                        emission = 5.0;

                        fresnel = 0.0;
                    }
                } else { // Beacon:Obsidian
                    float factor = color.r * 1.5;

                    smoothnessG = factor;
                    highlightMult = 2.0 + min1(smoothnessG * 2.0) * 1.5;
                    smoothnessG = min1(smoothnessG);

                    fresnel = 0.0;
                }
            
            } else /*if (mat == 31020)*/ { //
            
            }
        }
    } else {
        if (mat < 31032) {
            if (mat == 31024) { //
            
            } else /*if (mat == 31028)*/ { //
            
            }
        } else {
            if (mat == 31032) { //
            
            } else /*if (mat == 31036)*/ { //
            
            }
        }
    }
}