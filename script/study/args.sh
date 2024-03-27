# Проверка входных параметров
ARGS=2
E_BADARGS=65

if [ $# -ne "$ARGS" ]
then
  echo "Порядок использования: `basename $0` первое-число второе-число"
  exit $E_BADARGS
fi

gcd ()
{

                                 #  Начальное присваивание.
  dividend=$1                    #  В сущности, не имеет значения
  divisor=$2                     #+ какой из них больше.
                                 #  Почему?

  remainder=1                    #  Если переменные неинициализировать,
                                 #+ то работа сценария будет прервана по ошибке
                                 #+ в первом же цикле.

  until [ "$remainder" -eq 0 ]
	 if [[ $1 
  do
    let "remainder = $dividend % $divisor"
    dividend=$divisor            # Повторить цикл с новыми исходными данными
    divisor=$remainder
  done                           # алгоритм Эвклида

}                                # последнее $dividend и есть нод.


gcd $1 $2

echo; echo "НОД чисел $1 и $2 = $dividend"; echo
