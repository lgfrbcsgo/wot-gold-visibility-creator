import {Rgba} from "../types";

export interface TextureConfig {
    imageData: ImageData;
    packagePath: string;
}

export type Creator = (imageData: ImageData, color: Rgba) => Promise<Uint8Array>