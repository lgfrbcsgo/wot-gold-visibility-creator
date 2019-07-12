import {wrap} from 'comlink';
import {loadImageData} from './image';
import {createZipFile, ZipEntry} from './zip';
import {TextureCreator} from './types';
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
    const workerId = generateWorkerId();

    // Save worker to window object. Otherwise Edge and Safari will destroy the worker thread.
    self[workerId] = new Worker('./worker', {type: 'module'});

    try {
        const creator = wrap<TextureCreator>(self[workerId]);
        const textureData = await creator(imageData, color);
        return new Blob([textureData]);
    } finally {
        self[workerId].terminate();
        delete self[workerId];
    }
}

async function loadTextureResource(config: TextureConfig): Promise<TextureResource> {
    const imageUrl = require('../../res/worker/' + config.src);
    return {
        path: config.path,
        imageData: await loadImageData(imageUrl)
    };
}

function generateWorkerId(): string {
    return `creatorWorker-${Math.random().toFixed(16).toString().slice(2)}`;
}