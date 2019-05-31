export interface Color {
    r: number;
    g: number;
    b: number,
    alpha: number;
}


export interface Texture {
    imageData: ImageData;
    path: string;
}


export type WorkerExport = (color: Color, textureForward: Texture, textureDeferred: Texture) => Promise<Uint8Array>;