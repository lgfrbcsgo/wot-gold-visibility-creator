import {wrap} from 'comlink';
import {cache, loadImageData} from './util';
import {createZipWriter} from './zip';
import {Creator} from './types';
import {Rgba} from '../types';
import packageConfig from '../../res/worker/package.config.json';

const loadConfig = cache(() : Promise<TextureConfig[]> => Promise.all(
    packageConfig.textures
        .map(async ({ src, packagePath }) => {
            const imageUrl = require('../../res/worker/' + src);

            return {
                packagePath,
                imageData: await loadImageData(imageUrl)
            };
        }))
);

export async function createModPackage(color: Rgba): Promise<Blob> {
    const worker = new Worker('./creator', {type: 'module'});
    try {
        const creator = wrap<Creator>(worker);
        const zipWriter = await createZipWriter();

        for (const {packagePath, imageData} of await loadConfig()) {
            const textureData = await creator(imageData, color);
            await zipWriter.add(packagePath, new Blob([textureData]));
        }

        return await zipWriter.close();
    } finally {
        worker.terminate()
    }
}

interface TextureConfig {
    imageData: ImageData;
    packagePath: string;
}