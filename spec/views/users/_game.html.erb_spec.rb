require 'rails_helper'

RSpec.describe 'users/_game', type: :view do
  # Подготовим объект game для использования в тестах, где он понадобится
  let(:game) do
    build_stubbed(
      :game, id: 15, created_at: Time.parse('2023.01.27, 23:30'), current_level: 10, prize: 1000
    )
  end

  # Этот код будет выполнен перед каждым it-ом
  before(:each) do
    # Разрешаем объекту game в ответ на вызов метода status возвращать символ :in_progress
    allow(game).to receive(:status).and_return(:in_progress)

    # Рендерим наш фрагмент с нужным объектом
    render partial: 'users/game', object: game
  end

  # Проверяем, что фрагмент выводит id игры
  it 'renders game id' do
    expect(rendered).to match '15'
  end

  # Проверяем, что фрагмент выводит время, когда игра началась
  it 'renders game start time' do
    expect(rendered).to match '27 янв., 21:30'
  end

  # Проверяем, что фрагмент выводит текущий уровень
  it 'renders game current question' do
    expect(rendered).to match '10'
  end

  # Проверяем, что фрагмент выводит статус игры
  it 'renders game status' do
    expect(rendered).to match 'в процессе'
  end

  # Проверяем, что фрагмент выводит текущий выигрыш игрока
  it 'renders game prize' do
    expect(rendered).to match '1 000 ₽'
  end
end