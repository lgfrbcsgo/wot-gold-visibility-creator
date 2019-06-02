import {wrap} from 'comlink';
import {Color} from '../common';

import forwardResource from '../../res/forward.png';
import deferredResource from '../../res/deferred.png';
import config from '../../res/config.json';
import {PackageCreator} from "./common";

const worker = wrap(new Worker('./worker', {type: 'module'})) as PackageCreator;

const loadForward = lazy(() => loadImageData(forwardResource));
const loadDeferred = lazy(() => loadImageData(deferredResource));

export async function runWorker(color: Color): Promise<any> {
    return await worker({
        color,
        forward: {
            imageData: await loadForward(),
            path: config.paths.forward
        },
        deferred: {
            imageData: await loadDeferred(),
            path: config.paths.deferred
        }
    });
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

function lazy<T, V>(innerFunc: () => V) {
    let result: V;
    let didRun = false;
    return () => {
        if (!didRun) {
            result = innerFunc();
            didRun = true;
        }
        return result;
    }
}
