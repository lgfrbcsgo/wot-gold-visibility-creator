const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const WasmPackPlugin = require('@wasm-tool/wasm-pack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const WorkerPlugin = require('worker-plugin');

const purgecss = require('@fullhuman/postcss-purgecss');
const cssnano = require('cssnano');

const project = __dirname;
const dist = path.resolve(project, 'dist');
const src = path.resolve(project, 'src');

const createConfig = (inProdMode, inDevMode) => ({
    entry: path.resolve(src, 'index.ts'),
    ...inDevMode({
        mode: 'development',
        devtool: 'eval-source-map'
    }),
    ...inProdMode({
        mode: 'production',
        devtool: 'source-map'
    }),
    output: {
        path: dist,
        filename: '[name].[hash].js',
        globalObject: 'self',
        ...inProdMode({
            publicPath: '/wot-gold-visibility-creator/'
        })
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
                    ...inDevMode([{
                        loader: 'elm-hot-webpack-loader'
                    }]),
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
                use: {
                    loader: 'babel-loader'
                }
            },
            {
                test: /\.css$/,
                use: [
                    {loader: 'style-loader'},
                    {
                        loader: 'css-loader',
                        options: {
                            importLoaders: 1,
                            modules: {
                                ...inDevMode({
                                    localIdentName: '[path][name]__[local]--[hash:base64:5]'
                                }),
                                ...inProdMode({
                                    localIdentName: '[hash:base64]'
                                })
                            }
                        }
                    },
                    {
                        loader: 'postcss-loader',
                        options: {
                            plugins: [
                                // to catch errors early, don't disable purgecss in dev mode
                                purgecss({
                                    content: [
                                        './src/**/*.elm',
                                        './src/**/*.ts'
                                    ],
                                }),
                                ...inProdMode([
                                    cssnano({
                                        preset: 'default',
                                    })
                                ])
                            ]
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
            },
            {
                test: /\.hbs$/,
                loader: 'handlebars-loader'
            },
        ]
    },
    devServer: {
        contentBase: dist,
        historyApiFallback: {
            rewrites: [{
                from: /.+/,
                to: (context) => `${context.parsedUrl.pathname}.html`
            }]
        }
    },
    plugins: [
        new CleanWebpackPlugin(),
        new HtmlWebpackPlugin({
            filename: 'index.html',
            template: path.resolve(src, 'index.hbs'),
            ...inDevMode({
                includeErrorRedirect: false
            }),
            ...inProdMode({
                includeErrorRedirect: true
            })
        }),
        new HtmlWebpackPlugin({
            filename: 'error.html',
            template: path.resolve(src, 'error.hbs'),
            inject: false
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