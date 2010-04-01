package septenary.duelparty {
    import flash.geom.Point;

    public class TrainCarManager {

        protected var _frontCar:TrainCarMovement;

        public function TrainCarManager(frontCar:TrainCarMovement) {
            _frontCar = frontCar;
        }

        public function update():void {
            executeFunctionOnCars("update");
        }

        public function executeFunctionOnCars(funcName:String, args:Array=null, includeFront:Boolean=true):void {
            var nextCar:TrainCarMovement = includeFront ? _frontCar : _frontCar.carBehind;
            while (nextCar != null) {
                nextCar[funcName].apply(nextCar, args);
                nextCar = nextCar.carBehind;
            }
        }

        public function attachCar(car:TrainCarMovement, toFront:Boolean):void {
            if (car.manager != this) car.manager = this;
            
            if (toFront) {
                _frontCar.insertCar(car, toFront);
                _frontCar = car;
            } else {
                getBackCar().insertCar(car, toFront);
            }
        }

        public function moveTo(pt:Point, callback:Function):void {
            _frontCar.moveTo(pt, callback);
        }

        protected function getBackCar():TrainCarMovement {
            var nextCar:TrainCarMovement = _frontCar;
            while (nextCar.carBehind != null) {
                nextCar = nextCar.carBehind;
            }
            return nextCar;
        }
    }
}