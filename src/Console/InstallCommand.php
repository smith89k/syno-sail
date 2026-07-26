<?php

namespace Smith89k\SynoSail\Console;

use Illuminate\Console\Command;

class InstallCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'syno-sail:install';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Install the SynoSail configuration files for Docker deployment';

    /**
     * Execute the console command.
     */
    public function handle(): void
    {
        $this->info('Installing SynoSail Configuration...');

        $this->callSilent('vendor:publish', ['--tag' => 'syno-sail-stubs', '--force' => true]);

        $this->info('SynoSail configuration installed successfully.');
        $this->comment('Please check the docker-compose.yml file and configure it according to your needs.');
    }
}
