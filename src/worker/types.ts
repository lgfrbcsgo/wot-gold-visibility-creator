import {Rgba} from '../types';

/**
 * Defines contract between creator worker and main thread.
 */
export type TextureCreator = (imageData: ImageData, color: Rgba) => Promise<Uint8Array>