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

// custom element to use the virtual DOM of Elm to apply event listeners on the window object
class WindowEventProxy extends HTMLElement {
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

customElements.define('window-event-proxy', WindowEventProxy);