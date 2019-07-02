import {wrap, Remote} from 'comlink';
import {loadImageData} from './util';
import {createZipWriter} from './zip';
import {Creator, TextureConfig} from './types';
import {Rgba} from '../types';
import packageConfig from '../../res/worker/package.config.json';

const config = initConfig();

export async function createModPackage(color: Rgba): Promise<Blob> {
    const creatorWorker = new Worker('./creator', {type: 'module'});
    const creator = wrap(creatorWorker) as Remote<Creator>;

    const zipWriter = await createZipWriter();
    for (const {packagePath, imageData} of await config) {
        const textureData = await creator(imageData, color);
        await zipWriter.add(packagePath, new Blob([textureData]));
    }

    const blob = await zipWriter.close();
    creatorWorker.terminate();
    return blob;
}

async function initConfig() : Promise<TextureConfig[]> {
    const textures = packageConfig.textures.map(async ({ src, packagePath }) => {
        const imageUrl = require('../../res/worker/' + src);
        return {
            packagePath,
            imageData: await loadImageData(imageUrl)
        };
    });
    return await Promise.all(textures);
}