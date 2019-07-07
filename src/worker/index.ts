import {Remote, wrap} from 'comlink';
import {loadImageData} from './image';
import {createZipFile} from './zip';
import {Creator} from './types';
import {cache} from "../util";
import {Rgba} from '../types';
import packageConfig from '../../res/worker/package.config.json';

const creatorWorkerIds = generateCreatorWorkerIds();

const loadConfig = cache(() => Promise.all(
    packageConfig.textures.map(loadTextureConfig)
));

export async function createModPackage(color: Rgba): Promise<Blob> {
    const workerId = creatorWorkerIds.next().value;

    // Save worker to window object. Otherwise Edge and Safari will destroy the worker thread.
    self[workerId] = new Worker('./creator', {type: 'module'});

    try {
        const creator = wrap<Creator>(self[workerId]);
        const zipEntries = generateZipEntries(creator, color);
        return await createZipFile(zipEntries);
    } finally {
        self[workerId].terminate();
        delete self[workerId];
    }
}

async function* generateZipEntries(creator: Remote<Creator>, color: Rgba) {
    for (const {path, imageData} of await loadConfig()) {
        const textureData = await creator(imageData, color);
        const content = new Blob([textureData]);
        yield {path, content};
    }
}

function* generateCreatorWorkerIds() {
    let sequenceNumber = 0;
    while (true) {
        yield 'creatorWorker_' + sequenceNumber;
        sequenceNumber++;
    }
}

async function loadTextureConfig({src, path}: {src: string, path: string}) {
    const imageUrl = require('../../res/worker/' + src);
    return {
        path,
        imageData: await loadImageData(imageUrl)
    };
}