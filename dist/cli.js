#!/usr/bin/env node
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const zx_1 = require("zx");
const prompts_1 = require("@inquirer/prompts");
async function main() {
    // Prompt the user to select an action
    const action = await (0, prompts_1.select)({
        message: 'What do you want to do?',
        choices: [
            { name: 'A', value: 'node_version' },
            { name: 'B', value: 'npm_version' },
            { name: 'C', value: 'pwd' }
        ],
    });
    // Perform an action based on the user's choice
    let pwd;
    switch (action) {
        case 'node_version':
            pwd = await (0, zx_1.$) `node -v`;
            break;
        case 'npm_version':
            pwd = await (0, zx_1.$) `npm -v`;
            break;
        case 'pwd':
            pwd = await (0, zx_1.$) `pwd`;
            break;
        default:
            (0, zx_1.echo)('No valid option selected.');
            break;
    }
    if (pwd)
        console.log(pwd.stdout); // Explicitly output the result
}
// Run the main function
main();
