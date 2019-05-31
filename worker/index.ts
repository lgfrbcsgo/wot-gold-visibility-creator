import {wrap} from "comlink";
import {ColorOptions, PackageCreator} from './types';

import forwardResourcePath from './res/forward.png';
import deferredResourcePath from './res/deferred.png';
import packagePaths from './res/paths.json';

const createPackage = wrap(
    new Worker('./worker', {type: 'module'})
) as PackageCreator;

const forwardImageData = loadImageData(forwardResourcePath);
const deferredImageData = loadImageData(deferredResourcePath);

export async function run(color: ColorOptions): Promise<any> {
    return await createPackage({
        color,
        forward: {
            imageData: await forwardImageData,
            path: packagePaths.forward
        },
        deferred: {
            imageData: await deferredImageData,
            path: packagePaths.deferred
        }
    });
}

// TODO have a look at https://github.com/GoogleChromeLabs/squoosh/blob/master/src/lib/util.ts
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

async function loadImage(url: string): Promise<HTMLImageElement> {
    return await new Promise((resolve, reject) => {
        const image = new Image();
        image.onload = () => resolve(image);
        image.onerror = () => reject();
        image.src = url;
    });
}
