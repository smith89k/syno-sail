<?php

namespace Smith89k\Synodocker\Console;

use Illuminate\Console\Command;

class InstallCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'synodocker:install';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Install the Synodocker configuration files for Docker deployment';

    /**
     * Execute the console command.
     */
    public function handle(): void
    {
        $this->info('Installing Synodocker Configuration...');

        $this->callSilent('vendor:publish', ['--tag' => 'synodocker-stubs', '--force' => true]);

        $this->info('Synodocker configuration installed successfully.');
        $this->comment('Please check the docker-compose.yml file and configure it according to your needs.');
    }
}
