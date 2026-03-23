<div class="loader-container">
    <div class="sphere-core"></div>
    <div class="ring_ ring-1_"></div>
    <div class="ring_ ring-2_"></div>
    <div class="ring_ ring-3_"></div>
</div>

<style>
    .loader-container {
        position: relative;
        width: 150px;
        height: 150px;
        perspective: 800px;
        transform-style: preserve-3d;
    }

    .sphere-core {
        position: absolute;
        width: 60px;
        height: 60px;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: radial-gradient(circle at 40% 40%, #34d399, #0d9488);
        border-radius: 50%;
        box-shadow: 0 0 25px rgba(52, 211, 153, 0.5);
        animation: pulse 2s cubic-bezier(0.5, 0, 0.5, 1) infinite;
    }

    .ring_ {
        position: absolute;
        width: 100%;
        height: 100%;
        border: 2px solid rgba(52, 211, 153, 0.7);
        border-radius: 50%;
        box-shadow: 0 0 15px rgba(52, 211, 153, 0.3);
        transform-style: preserve-3d;
    }

    .ring-1_ {
        animation: rotateX 2.5s cubic-bezier(0.65, 0, 0.35, 1) infinite;
    }

    .ring-2_ {
        animation: rotateY 2s cubic-bezier(0.55, 0, 0.45, 1) infinite;
        width: 120px;
        height: 120px;
        top: 15px;
        left: 15px;
        border-color: rgba(52, 211, 153, 0.5);
    }

    .ring-3_ {
        animation: rotateXY 3s cubic-bezier(0.7, 0, 0.3, 1) infinite;
        width: 90px;
        height: 90px;
        top: 30px;
        left: 30px;
        border-color: rgba(52, 211, 153, 0.3);
    }

    @keyframes rotateX {
        0% {
            transform: rotateX(0deg);
        }
        50% {
            transform: rotateX(180deg);
        }
        100% {
            transform: rotateX(360deg);
        }
    }

    @keyframes rotateY {
        0% {
            transform: rotateY(0deg);
        }
        50% {
            transform: rotateY(180deg);
        }
        100% {
            transform: rotateY(360deg);
        }
    }

    @keyframes rotateXY {
        0% {
            transform: rotateX(0deg) rotateY(0deg);
        }
        50% {
            transform: rotateX(90deg) rotateY(180deg);
        }
        100% {
            transform: rotateX(360deg) rotateY(360deg);
        }
    }

    @keyframes pulse {
        0%,
        100% {
            transform: translate(-50%, -50%) scale(1);
            box-shadow: 0 0 25px rgba(52, 211, 153, 0.5);
        }
        50% {
            transform: translate(-50%, -50%) scale(1.1);
            box-shadow: 0 0 35px rgba(52, 211, 153, 0.7);
        }
    }

    .loader-container:hover .sphere-core {
        background: radial-gradient(circle at 40% 40%, #5eead4, #14b8a6);
        box-shadow: 0 0 35px rgba(94, 234, 212, 0.7);
    }

    .loader-container:hover .ring_ {
        border-color: rgba(94, 234, 212, 0.7);
        box-shadow: 0 0 20px rgba(94, 234, 212, 0.5);
    }
</style>