<?php

namespace Smith89k\SynoSail;

use Illuminate\Support\ServiceProvider;

class SynoSailServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if ($this->app->runningInConsole()) {
            $this->commands([
                Console\InstallCommand::class,
            ]);

            $this->publishes([
                __DIR__.'/../stubs/docker' => base_path('docker'),
                __DIR__.'/../stubs/docker-compose.yml' => base_path('docker-compose.yml'),
                __DIR__.'/../stubs/Dockerfile' => base_path('Dockerfile'),
                __DIR__.'/../stubs/.env.docker.example' => base_path('.env.docker.example'),
                __DIR__.'/../stubs/.dockerignore' => base_path('.dockerignore'),
                __DIR__.'/../stubs/.github' => base_path('.github'),
            ], 'syno-sail-stubs');
        }
    }

    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }
}
