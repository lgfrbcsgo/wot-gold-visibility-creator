import {wrap} from 'comlink';
import {createZipFile, ZipEntry} from './zip';
import {WorkerExports} from './types';
import {cache, limitConcurrency, LazyPromise} from '../util';
import {Rgba} from '../types';
import {getImageBitmap, loadImage} from './image';

import packageConfig from '../../res/worker/package.config.json';

interface TextureConfig {
    path: string;
    src: string;
}

interface TextureResource {
    path: string;
    imageData: ImageData;
}

const loadResourcesCached = cache(
    () => Promise.all(
        packageConfig.map(loadResource)
    )
);

export async function createModPackage(color: Rgba): Promise<Blob> {
    const resources = await loadResourcesCached();

    const zipEntries = limitConcurrency(
        2, resources.map(createTexture(color))
    );

    return await createZipFile(zipEntries);
}

function createTexture(color: Rgba): (data: TextureResource) => LazyPromise<ZipEntry> {
    return ({path, imageData}) =>
        async () => ({
            path,
            content: await encodeTexture(color, imageData)
        });
}

async function encodeTexture(color: Rgba, imageData: ImageData): Promise<Blob> {
    const workerId = `creatorWorker-${Math.random().toFixed(16).toString().slice(2)}`;

    // Save worker to window object. Otherwise Edge and Safari will destroy the worker thread.
    self[workerId] = new Worker('./wasm-worker', {type: 'module'});

    try {
        const {encodeTexture} = wrap<WorkerExports>(self[workerId]);
        const textureData = await encodeTexture(imageData, color);
        return new Blob([textureData]);
    } finally {
        self[workerId].terminate();
        delete self[workerId];
    }
}

async function loadResource({src, path}: TextureConfig): Promise<TextureResource> {
    const imageUrl: string = require('../../res/worker/' + src);
    const image = await loadImage(imageUrl);
    const imageData = getImageBitmap(image);
    return {imageData, path};
}