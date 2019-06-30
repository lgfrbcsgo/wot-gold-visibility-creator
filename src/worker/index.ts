import {wrap, transfer} from 'comlink';
import {Rgba} from '../types';
import {TextureConfig, CreatorWorkerInitializer} from './types';
import {loadImageData} from './util';
import packageConfig from '../../res/worker/package.config.json';
import {createWriter} from "./zip";


const worker = new Worker('./creator', {type: 'module'});
const initPromise = init();


export async function createModPackage(color: Rgba): Promise<Blob> {
    // Keep a reference to the worker, otherwise Edge will garbage collect it!
    // "await" worker to not get optimized away during the build.
    await worker;

    const zipWriter = await createWriter();
    const config = await initPromise;
    for (const {packagePath, worker} of config) {
        const texture = await worker.create(color);
        await zipWriter.add(packagePath, new Blob([texture]));
    }

    return await zipWriter.close();
}


async function init() : Promise<TextureConfig[]> {
    const initializeWorker = wrap<CreatorWorkerInitializer>(worker);
    const textures = packageConfig.textures.map(async ({ src, packagePath }) => {
        const imageUrl = require('../../res/worker/' + src);
        const imageData = await loadImageData(imageUrl);
        const textureConfig: TextureConfig = {
            packagePath,
            worker: await initializeWorker(imageData)
        };
        return transfer(textureConfig, [imageData.data.buffer]);
    });
    return await Promise.all(textures);
}