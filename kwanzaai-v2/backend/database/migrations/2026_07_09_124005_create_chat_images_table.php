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
        Schema::create('chat_images', function (Blueprint $table) {
            $table->integer('id')->primary()->autoIncrement();
            $table->integer('chat_room_id');
            $table->integer('message_id');
            $table->string('image_path');
            $table->timestamps();

            $table->foreign('chat_room_id')->on('chat_rooms')->references('id')->onDelete('cascade')->onUpdate('cascade');
            $table->foreign('message_id')->on('messages')->references('id')->onDelete('cascade')->onUpdate('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('chat_images');
    }
};
