import {wrap} from 'comlink';
import {createZipFile, ZipEntry} from './zip';
import {ImageData, WorkerExports} from './types';
import {cache, executeConcurrently, LazyPromise} from '../util';
import {Rgba} from '../types';
import packageConfig from '../../res/worker/package.config.json';

interface TextureConfig {
    path: string;
    src: string;
}

interface TextureResource {
    path: string;
    imageData: ImageData;
}

const loadResources = cache(() => Promise.all(
    packageConfig.map(loadTextureResource)
));

export async function createModPackage(color: Rgba): Promise<Blob> {
    const resources = await loadResources();
    const createZipEntryPartial = createZipEntry(color);
    const zipEntries = executeConcurrently(
        2, resources.map(createZipEntryPartial)
    );
    return await createZipFile(zipEntries);
}

function createZipEntry(color: Rgba): (data: TextureResource) => LazyPromise<ZipEntry> {
    return ({path, imageData}) => async () => ({
        path,
        content: await createTexture(color, imageData)
    })
}

async function createTexture(color: Rgba, imageData: ImageData): Promise<Blob> {
    for (const {encodeTexture} of spawnWorker()) {
        const textureData = await encodeTexture(imageData, color);
        return new Blob([textureData]);
    }
    throw 'Could not spawn worker.';
}

async function loadTextureResource(config: TextureConfig): Promise<TextureResource> {
    for (const {decodeResource} of spawnWorker()) {
        const imageUrl = require('../../res/worker/' + config.src);
        const response = await fetch(imageUrl);
        const data = await response.arrayBuffer();

        const imageData = await decodeResource(new Uint8Array(data));
        return {
            imageData,
            path: config.path
        };
    }
    throw 'Could not spawn worker.';
}


/**
 * Python style context manager to be used in for each loop.
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