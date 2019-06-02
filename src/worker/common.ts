import {Color} from "../common";

export interface TextureOptions {
    imageData: ImageData;
    path: string;
}

export interface PackageOptions {
    color: Color;
    forward: TextureOptions;
    deferred: TextureOptions;
}

export type PackageCreator = (options: PackageOptions) => Promise<Uint8Array>;