import {wrap} from 'comlink';
import {loadImageData} from './image';
import {createZipFile, ZipEntry} from './zip';
import {TextureCreator} from './types';
import {cache, executeConcurrently, LazyPromise} from "../util";
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
    packageConfig.map(loadTextureResource())
));

export async function createModPackage(color: Rgba): Promise<Blob> {
    const config = await loadResources();
    const zipEntries = executeConcurrently(
        2, config.map(createZipEntry(color))
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
    const workerId = generateWorkerId();

    // Save worker to window object. Otherwise Edge and Safari will destroy the worker thread.
    self[workerId] = new Worker('./texture', {type: 'module'});

    let textureData: Uint8Array;
    try {
        const creator = wrap<TextureCreator>(self[workerId]);
        textureData = await creator(imageData, color);
    } finally {
        self[workerId].terminate();
        delete self[workerId];
    }

    return new Blob([textureData]);
}

function loadTextureResource(): (config: TextureConfig) => Promise<TextureResource> {
    return async ({path, src}) => {
        const imageUrl = require('../../res/worker/' + src);
        return {
            path,
            imageData: await loadImageData(imageUrl)
        };
    }
}

function generateWorkerId(): string {
    return `creatorWorker-${Math.random().toFixed(16).toString().slice(2)}`;
}