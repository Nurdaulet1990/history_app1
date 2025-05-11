import 'question.dart';

// Computer Science first chapter questions - Algorithms
final List<Question> csFirstChapterQuestions = [
  Question(
    id: 1,
    text: 'Алгоритмнің анықтамасы қандай?',
    options: [
      'Есептеуіш үдерісті дұрыс ұйымдастыратын нақты анықталған ережелер жиынтығы',
      'Компьютерлік бағдарлама',
      'Математикалық формула',
      'Деректер жиыны'
    ],
    correctOptionIndex: 0,
  ),
  Question(
    id: 2,
    text: 'Алгоритмнің қасиеттері қандай?',
    options: [
      'Түсініктілік, анықтылық, дискреттілік',
      'Түсініктілік, анықтылық, дискреттілік, нәтижелілік, жалпылық',
      'Жылдамдық, тиімділік, дәлдік',
      'Жылдамдық, анықтылық, дискреттілік'
    ],
    correctOptionIndex: 1,
  ),
  Question(
    id: 3,
    text: 'Рекурсия дегеніміз не?',
    options: [
      'Өзін-өзі шақыратын функция',
      'Циклдардың бір түрі',
      'Берілгендер құрылымы',
      'Алгоритмді оңтайландыру әдісі'
    ],
    correctOptionIndex: 0,
  ),
  Question(
    id: 4,
    text: 'O(n) уақыт күрделілігі бар алгоритмге мысал?',
    options: [
      'Quicksort',
      'Binary search',
      'Linear search',
      'Bubble sort'
    ],
    correctOptionIndex: 2,
  ),
  Question(
    id: 5,
    text: 'Бинарлық іздеу алгоритмінің уақыт күрделілігі қандай?',
    options: [
      'O(n²)',
      'O(n)',
      'O(log n)',
      'O(n log n)'
    ],
    correctOptionIndex: 2,
  ),
  Question(
    id: 6,
    text: 'Алгоритмдегі "жадылық" (greedy) тәсіл дегеніміз не?',
    options: [
      'Әрбір қадамда ең жақсы таңдауды жасайтын алгоритм',
      'Көп жады қолданатын алгоритм',
      'Динамикалық бағдарламалау әдісі',
      'Барлық мүмкін нұсқаларды қарастыратын алгоритм'
    ],
    correctOptionIndex: 0,
  ),
  Question(
    id: 7,
    text: 'Сұрыптау алгоритмдерінің ішіндегі ең тұрақты алгоритм?',
    options: [
      'Bubble sort',
      'Quick sort',
      'Merge sort',
      'Selection sort'
    ],
    correctOptionIndex: 2,
  ),
  Question(
    id: 8,
    text: 'NP-complete мәселенің мысалы?',
    options: [
      'Binary search',
      'Travelling salesman problem',
      'Merge sort',
      'Linear search'
    ],
    correctOptionIndex: 1,
  ),
  Question(
    id: 9,
    text: 'Динамикалық бағдарламалау қандай мәселелерді шешу үшін қолданылады?',
    options: [
      'Кез-келген алгоритмдік мәселе',
      'Оңтайлы ішкі құрылымы бар мәселелер',
      'Тек графтық алгоритмдер',
      'Тек сұрыптау алгоритмдері'
    ],
    correctOptionIndex: 1,
  ),
  Question(
    id: 10,
    text: 'Қандай алгоритм кезекті пайдаланады?',
    options: [
      'Depth-First Search',
      'Breadth-First Search',
      'Binary Search',
      'Quick Sort'
    ],
    correctOptionIndex: 1,
  ),
  Question(
    id: 11,
    text: 'Дейкстра алгоритмі не үшін қолданылады?',
    options: [
      'Графтағы ең қысқа жолды табу',
      'Массивті сұрыптау',
      'Графты бояу',
      'Минималды тік ағашты табу'
    ],
    correctOptionIndex: 0,
  ),
  Question(
    id: 12,
    text: 'Кездейсоқ алгоритмдердің ерекшелігі қандай?',
    options: [
      'Кездейсоқ деректерді өңдеу',
      'Шешімді кездейсоқ таңдау арқылы шешу',
      'Әрдайым дұрыс нәтиже шығаратын алгоритмдер',
      'Жылдам жұмыс істейтін алгоритмдер'
    ],
    correctOptionIndex: 1,
  ),
  Question(
    id: 13,
    text: 'Пойнтер қандай мақсатта қолданылады?',
    options: [
      'Графика салу үшін',
      'Жадыдағы орналасқан жерді көрсету үшін',
      'Файлды ашу үшін',
      'Деректерді сұрыптау үшін'
    ],
    correctOptionIndex: 1,
  ),
  Question(
    id: 14,
    text: 'A* алгоритмі қандай мәселені шешеді?',
    options: [
      'Сұрыптау',
      'Іздеу',
      'Графтағы ең қысқа жолды табу',
      'Шифрлеу'
    ],
    correctOptionIndex: 2,
  ),
  Question(
    id: 15,
    text: 'Bubble sort алгоритмінің уақыт күрделілігі қандай?',
    options: [
      'O(n)',
      'O(n²)',
      'O(log n)',
      'O(n log n)'
    ],
    correctOptionIndex: 1,
  ),
]; 