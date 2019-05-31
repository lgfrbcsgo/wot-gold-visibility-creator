export interface ColorOptions {
    r: number;
    g: number;
    b: number;
    alpha: number;
}

export interface TextureOptions {
    imageData: ImageData;
    path: string;
}

export interface PackageOptions {
    color: ColorOptions;
    forward: TextureOptions;
    deferred: TextureOptions;
}

export type WorkerExport = (options: PackageOptions) => Promise<Uint8Array>;