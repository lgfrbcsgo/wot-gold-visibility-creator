export interface ColorOptions {
    red: number;
    green: number;
    blue: number;
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

