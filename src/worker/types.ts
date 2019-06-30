import {Rgba} from "../types";

export interface TextureConfig {
    worker: CreatorWorker;
    packagePath: string;
}

export interface CreatorWorker {
    create(color: Rgba): Uint8Array;
}

export type CreatorWorkerInitializer = (config: ImageData) => Promise<CreatorWorker>