<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('ai_messages', function (Blueprint $table) {
            $table->integer('id')->primary()->autoIncrement();
            $table->integer('conversation_id');
            $table->enum('role',['user','assistant','tool']);
            $table->text('message')->nullable();
            $table->enum('type',['text','tool_call','tool_result'])->default('text');
            $table->string('tool_name')->nullable();
            $table->json('tool_calls')->nullable();
            $table->timestamps();

            $table->foreign('conversation_id')->on('conversations')->references('id')->onDelete('cascade')->onUpdate('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ai_messages');
    }
};
