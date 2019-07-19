export type Drawable = HTMLImageElement | ImageBitmap;

export function getImageBitmap(image: Drawable): ImageData {
    const {height, width} = image;
    const canvas = document.createElement('canvas') as HTMLCanvasElement;
    canvas.height = height;
    canvas.width = width;

    // cast to CanvasRenderingContext2D as getContext is guaranteed to not be null on a newly created Canvas
    const ctx = canvas.getContext('2d') as CanvasRenderingContext2D;
    ctx.drawImage(image, 0, 0);
    return ctx.getImageData(0, 0, width, height);
}

export async function loadImage(url: string): Promise<Drawable> {
    const image = new Image();
    image.src = url;
    image.decoding = 'async';

    const loading = new Promise<HTMLImageElement>((resolve, reject) => {
        image.onload = () => resolve(image);
        image.onerror = () => reject(new Error(`Image(src=${url}) failed to load`));
    });

    if (self.createImageBitmap) {
        // decode image data off the main thread in Firefox
        return await self.createImageBitmap(await loading);
    }

    if (image.decode) {
        // decode image data off the main thread in Chrome and Safari
        await image.decode();
    }

    return await loading;
}
