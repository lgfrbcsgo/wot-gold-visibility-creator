const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const WasmPackPlugin = require('@wasm-tool/wasm-pack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const WorkerPlugin = require('worker-plugin');

const project = __dirname;
const dist = path.resolve(project, 'dist');
const src = path.resolve(project, 'src');

const createConfig = (inProdMode, inDevMode) => ({
    entry: './src/index.ts',
    ...inDevMode({
        mode: 'development'
    }),
    ...inProdMode({
        mode: 'production'
    }),
    output: {
        path: dist,
        publicPath: '/wot-gold-visibility-creator/',
        filename: '[name].[hash].js',
        globalObject: 'self'
    },
    resolve: {
        extensions: ['.elm', '.wasm', '.ts', '.mjs', '.js', '.json']
    },
    module: {
        rules: [
            {
                test: /\.elm$/,
                use: [
                    {
                        loader: 'elm-css-modules-loader'
                    },
                    {
                        loader: 'elm-hot-webpack-loader'
                    },
                    {
                        loader: 'elm-webpack-loader',
                        options: {
                            cwd: project,
                            ...inDevMode({
                                debug: true
                            }),
                            ...inProdMode({
                                optimize: true
                            })
                        }
                    }
                ]
            },
            {
                test: /\.(ts|mjs|js)$/,
                include: [
                    src,
                    path.resolve('node_modules/comlink')
                ],
                use:  {
                    loader: 'babel-loader'
                }
            },
            {
                test: /\.css$/,
                use: [
                    { loader:  'style-loader' },
                    {
                        loader: 'css-loader',
                        options: {
                            modules: true,
                        }
                    }
                ]
            },
            {
                test: /\.(png|svg)$/,
                use: {
                    loader: 'url-loader',
                    options: {
                        limit: 8192,
                        fallback: 'file-loader',
                        name: '[hash].[ext]'
                    }
                }
            }
        ]
    },
    devServer: {
        contentBase: dist,
    },
    plugins: [
        new CleanWebpackPlugin(),
        new HtmlWebpackPlugin({
            filename: 'index.html',
            template: path.resolve(src, 'index.html')
        }),
        new WasmPackPlugin({
            crateDirectory: path.resolve(src, 'worker/wasm'),
            forceMode: 'production'
        }),
        new WorkerPlugin({
            globalObject: 'self'
        })
    ]
});

module.exports = (production = true) => createConfig(inProdMode(production), inDevMode(production));

function inProdMode(production) {
    return arrayOrObject => {
        if (production) {
            return arrayOrObject;
        } else {
            return Array.isArray(arrayOrObject) ? [] : {};
        }
    }
}

function inDevMode(isProd) {
    return inProdMode(!isProd);
}