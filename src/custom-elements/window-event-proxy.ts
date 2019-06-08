// custom element to use the virtual DOM of Elm to apply event listeners on the window object
class WindowEventProxy extends HTMLElement {
    private connected = false;

    private listeners: any[] = [];

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


    addEventListener(...listener: any[]): void {
        this.listeners.push(listener);
        if (this.connected) {
            window.addEventListener.apply(window, listener);
        }
    }

    removeEventListener(...listener: any[]): void {
        const index = this.listeners.findIndex(otherListener => {
            // compares by reference, will break for complex listener options
            return otherListener.length === listener.length &&
                otherListener.every((value: any, index: number) => value === listener[index])
        });
        if (0 <= index) {
            this.listeners.splice(index, 1);
        }
        if (this.connected) {
            window.removeEventListener.apply(window, listener);
        }
    }
}

customElements.define('window-event-proxy', WindowEventProxy);