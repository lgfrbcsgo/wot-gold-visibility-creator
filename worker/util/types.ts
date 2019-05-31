export interface WorkerOptions {
    color: ColorOptions,
    textureForward: TextureMetadata,
    textureDeferred: TextureMetadata,
}

export interface ColorOptions {
    r: number;
    g: number;
    b: number,
    alpha: number;
}

export interface TextureMetadata {
    height: number;
    width: number;
    path: string;
}