import {wrap} from 'comlink';
import {createZipFile, ZipEntry} from './zip';
import {WorkerExports} from './types';
import {cache, executeConcurrently, LazyPromise} from '../util';
import {Rgba} from '../types';
import packageConfig from '../../res/worker/package.config.json';
import {loadImageData} from './image';

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

    const zipEntries = executeConcurrently(
        2, resources.map(createZipEntry(color))
    );

    return await createZipFile(zipEntries);
}

function createZipEntry(color: Rgba): (data: TextureResource) => LazyPromise<ZipEntry> {
    return ({path, imageData}) =>
        async () => ({
            path,
            content: await createTexture(color, imageData)
        });
}

async function createTexture(color: Rgba, imageData: ImageData): Promise<Blob> {
    for (const {encodeTexture} of spawnWorker()) {
        const textureData = await encodeTexture(imageData, color);
        return new Blob([textureData]);
    }
    throw 'Could not spawn worker.';
}

async function loadResource(config: TextureConfig): Promise<TextureResource> {
    const imageUrl = require('../../res/worker/' + config.src);
    return {
        imageData: await loadImageData(imageUrl),
        path: config.path
    };
}

/**
 * Python style context manager to be used in for of loop.
 */
function* spawnWorker() {
    const workerId = `creatorWorker-${Math.random().toFixed(16).toString().slice(2)}`;

    // Save worker to window object. Otherwise Edge and Safari will destroy the worker thread.
    self[workerId] = new Worker('./worker', {type: 'module'});

    try {
        yield wrap<WorkerExports>(self[workerId]);
    } finally {
        self[workerId].terminate();
        delete self[workerId];
    }
}