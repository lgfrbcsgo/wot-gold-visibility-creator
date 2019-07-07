import {Remote, wrap} from 'comlink';
import {loadImageData} from './image';
import {ZipEntry, zipFile} from './zip';
import {Creator} from './types';
import {cache} from "../util";
import {Rgba} from '../types';
import packageConfig from '../../res/worker/package.config.json';

interface TextureConfig {
    imageData: ImageData;
    path: string;
}

const loadConfig = cache(() : Promise<TextureConfig[]> => Promise.all(
    packageConfig.textures
        .map(async ({ src, path }) => {
            const imageUrl = require('../../res/worker/' + src);

            return {
                path,
                imageData: await loadImageData(imageUrl)
            };
        }))
);

export async function createModPackage(color: Rgba): Promise<Blob> {
    const worker = new Worker('./creator', {type: 'module'});
    try {
        const creator = wrap<Creator>(worker);
        return await zipFile(generateZipEntries(creator, color));
    } finally {
        worker.terminate()
    }
}

async function* generateZipEntries(creator: Remote<Creator>, color: Rgba): AsyncIterableIterator<ZipEntry> {
    for (const {path, imageData} of await loadConfig()) {
        const textureData = await creator(imageData, color);
        const content = new Blob([textureData]);
        yield {path, content};
    }
}