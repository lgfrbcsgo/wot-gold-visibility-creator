export interface Color {
    r: number;
    g: number;
    b: number,
    alpha: number;
}

export interface Texture {
    data: Uint8Array,
    height: number;
    width: number;
    path: string;
}

export type CreatePackageFunction = (color: Color, textureForward: Texture, textureDeferred: Texture) => Promise<Uint8Array>;