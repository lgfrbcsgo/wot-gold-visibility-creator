function doesCapture(listenerOptions?: any): boolean {
    if (typeof listenerOptions === 'boolean') {
        return listenerOptions;
    }
    if (typeof listenerOptions === 'object' && listenerOptions !== null) {
        return !!listenerOptions.capture;
    }
    return false;
}

interface Listener {
    type: any;
    handler: any;
    options?: any;
}

/**
 * Custom element which applies event handlers to the window when calling {@link addEventListener} on the element.
 * This is useful in Elm for applying custom event listeners on the window without ports.
 * That way we can leverage Elm's virtual DOM to handle the listeners for us.
 */
export class WindowEventProxy extends HTMLElement {
    private connected = false;

    private listeners: Listener[] = [];

    connectedCallback() {
        this.connected = true;
        this.listeners.forEach(listener => {
            window.addEventListener.apply(window, listener);
        });
    }

    disconnectedCallback() {
        this.connected = false;
        this.listeners.forEach(listener => {
            window.removeEventListener.apply(window, listener);
        });
    }


    addEventListener(type: any, handler: any, options?: any): void {
        this.listeners.push({ type, handler, options });
        if (this.connected) {
            window.addEventListener(type, handler, options);
        }
    }

    removeEventListener(type: any, handler: any, options?: any): void {
        const index = this.listeners.findIndex(otherListener => {
            return type === otherListener.type
                && handler === otherListener.handler
                && doesCapture(options) === doesCapture(otherListener.options);
        });
        if (0 <= index) {
            this.listeners.splice(index, 1);
        }
        if (this.connected) {
            window.removeEventListener(type, handler, options);
        }
    }
}