import {Rgba} from "../types";

export interface TextureConfig {
    imageData: ImageData;
    packagePath: string;
}

export interface CreatorWorker {
    create(color: Rgba): Uint8Array;
}

export type CreatorWorkerInitializer = (config: TextureConfig[]) => Promise<CreatorWorker>