import {Rgba} from '../types';

export interface ImageData {
    data: Uint8Array;
    width: number;
    height: number;
}

export interface WorkerExports {
    encodeTexture: TextureEncoder;
    decodeResource: ResourceDecoder;
}

export type TextureEncoder = (imageData: ImageData, color: Rgba) => Promise<Uint8Array>;

export type ResourceDecoder = (data: Uint8Array) => Promise<ImageData>;