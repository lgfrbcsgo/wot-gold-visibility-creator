import {Rgba} from '../types';


export interface WorkerExports {
    encodeTexture: TextureEncoder;
}

export type TextureEncoder = (imageData: ImageData, color: Rgba) => Promise<Uint8Array>;
