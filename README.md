# Zenmode

A new Flutter project.

## In Progress:
Добавить поддержку Web:
- [ ] Исправить вход через диплинки. Чет сложно и не получается ничего (

Добавить поддержку MacOS:
- [ ] Сгенерировать иконки
- [ ] Добавить скриншоты и описание
- [ ] Отправить на ревью

## TODO:

### Bugs:
- [ ] Отобразить ошибку если не удалось добавить эмодзик, а не просто ничего не делать. В таком случае теряется текст.
- [ ] Анимация в демо режиме авторизации стартует с паузой.
- [ ] Фиолетовый -> Черный в Material v3
- [ ] Убрать регенерацию эмодзи в демо режиме, при изменении размеров окна
- [ ] CI: Исправить ошибку с провижионом, посмотреть другой туториал

### Features:
- [ ] Предложить сохранить эмоции перед удалением аккаунта
- [ ] Донастроить Google и верифицировать консоль
- [ ] Донастроить Facebook и верифицировать консоль
- [ ] Сделать ввод текста модальным окошком
- [ ] При отображении эмодзиков, сверху отображать предложенные по тексту
- [ ] Сделать дни недели сверху как неделя с раскрытием по нажатию до месяца, очень крутая идея
- [ ] При скроле добавить пагинацию
- [ ] Сделать более оптимизированный скролл с переиспользованием каждого эмодзика как элемента
- [ ] Добавить смену шрифта на чернобелый в настройках
- [ ] Добавить смену размера шрифта в настройках
- [ ] Добавить драг энд дроп между элементами
- [ ] Изучить и переехать на go_router или другую хорошую систему навигации
- [ ] Заимплементить для macOS - https://github.com/GroovinChip/macos_ui

### Discovery:
- [ ] Сделать каждую эмоцию, как приватный канал в телеграмме
- [ ] Сделать таб бар с поиском и настройками

### DONE ✓
- [x] Вход через соцсети (Apple, Google, Facebook)
- [x] Обезопасить показ данных через политики в Supabase
- [x] Добавить Alert перед удалением аккаунта, удалить аккаунт реально
- [x] Вынести авторизацию в bottom sheet. Открытие при входе, блюр на заднем фоне. Если пользователь не залогинен, отобразить боттом шит с авторизацией и отображать на заднем фоне рандомные эмодзи которые медленно скролятся.

Terms of use - https://www.notion.so/sashkyn/Zenmode-Terms-of-Use-df179704b2d149b8a5a915296f5cb78f
