<?php
require '/home/itzashark/tugas/laramle/web-project/vendor/autoload.php';
$app = require_once '/home/itzashark/tugas/laramle/web-project/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();
$student = \App\Models\Student::first();
echo "Testing with NIS: " . $student->nis . " and Password: password\n";
