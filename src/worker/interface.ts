import {IRgba} from "../common";

export interface ITextureConfig {
    imageData: ImageData;
    packagePath: string;
}

export interface IWorker {
    create(color: IRgba): Uint8Array;
}

export type IWorkerInitializer = (config: ITextureConfig[]) => Promise<IWorker>