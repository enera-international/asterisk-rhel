#!/usr/bin/env node

import { $, echo, ProcessOutput } from 'zx';
import { select } from '@inquirer/prompts';

async function main() {
    // Prompt the user to select an action
    const action = await select({
        message: 'What do you want to do?',
        choices: [
            { name: 'A', value: 'node_version' },
            { name: 'B', value: 'npm_version' },
            { name: 'C', value: 'pwd' }
        ],
    });

    // Perform an action based on the user's choice
    let pwd: ProcessOutput | undefined
    switch (action) {
        case 'node_version':
            pwd = await $`node -v`;
            break;
        case 'npm_version':
            pwd = await $`npm -v`;
            break;
        case 'pwd':
            pwd = await $`pwd`;
            break;
        default:
            echo('No valid option selected.');
            break;
    }
    if (pwd)
        console.log(pwd.stdout);  // Explicitly output the result
}

// Run the main function
main();
