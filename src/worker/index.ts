import {wrap, transfer} from 'comlink';
import {Rgba} from '../types';
import {TextureConfig, CreatorWorkerInitializer, CreatorWorker} from './types';
import packageConfig from '../../res/worker/package.config.json';

const worker = new Worker('./worker', {type: 'module'});
const creatorWorker = initializeCreatorWorker(worker);

export async function createModPackage(color: Rgba): Promise<Uint8Array> {
    // keep a reference to the worker, otherwise Edge will garbage collect the worker!
    worker;
    const initializedWorker = await creatorWorker;
    return await initializedWorker.create(color);
}

async function initializeCreatorWorker(worker: Worker): Promise<CreatorWorker> {
    const config = await loadPackageConfig();
    return await wrap<CreatorWorkerInitializer>(worker)(config);
}

async function loadPackageConfig() : Promise<TextureConfig[]> {
    const textures = packageConfig.textures.map(async ({ src, packagePath }) => {
        const imageUrl = require('../../res/worker/' + src);
        const textureConfig: TextureConfig = {
            packagePath,
            imageData: await loadImageData(imageUrl)
        };
        return transfer(textureConfig, [textureConfig.imageData.data.buffer]);
    });
    return await Promise.all(textures);
}

async function loadImageData(url: string): Promise<ImageData> {
    const image = await loadImage(url);
    const canvas = document.createElement('canvas') as HTMLCanvasElement;
    canvas.height = image.height;
    canvas.width = image.width;
    // cast to CanvasRenderingContext2D as getContext is guaranteed to not be null on a newly created Canvas
    const ctx = canvas.getContext('2d') as CanvasRenderingContext2D;
    ctx.drawImage(image, 0, 0);
    return ctx.getImageData(0, 0, image.width, image.height);
}

async function loadImage(url: string): Promise<HTMLImageElement | ImageBitmap> {
    const image = new Image();
    image.src = url;
    image.decoding = 'async';

    const loading = new Promise<HTMLImageElement>((resolve, reject) => {
        image.onload = () => resolve(image);
        image.onerror = () => reject();
    });

    if (image.decode) {
        // decode image data off the main thread in Chrome and Safari
        await image.decode();
    }

    if (self.createImageBitmap) {
        // decode image data off the main thread in Firefox
        return await self.createImageBitmap(await loading);
    } else {
        return await loading;
    }
}
