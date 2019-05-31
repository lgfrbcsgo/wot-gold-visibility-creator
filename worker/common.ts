export interface ColorOptions {
    r: number;
    g: number;
    b: number;
    alpha: number;
}

export interface TextureOptions {
    imageData: ImageData;
    path: string;
}

export interface PackageOptions {
    color: ColorOptions;
    forward: TextureOptions;
    deferred: TextureOptions;
}

export type PackageCreator = (options: PackageOptions) => Promise<Uint8Array>;

export function lazy<T, V>(innerFunc: () => V) {
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

export async function loadImageData(url: string): Promise<ImageData> {
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