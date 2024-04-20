package main

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

const TEST_DB = "todo-clone-test.db"

func TestUpsertTodo(t *testing.T) {
	db, err := gorm.Open(sqlite.Open(TEST_DB), &gorm.Config{})
	if err != nil {
		t.Errorf("failed to connect database: %v", err)
	}
	defer func() {
		db.Migrator().DropTable(&Todo{}, &Pomodoro{})
	}()

	// AutoMigrate the schema
	db.AutoMigrate(&Todo{}, &Pomodoro{})
	repo := &repo{db: db}

	// Insert a todo
	pomodoros := []Pomodoro{{TodoID: 1, StartTime: time.Now(), Duration: 25}}
	todo := Todo{
		Name:      "Test",
		Type:      "test",
		Order:     time.Now(),
		Pomodoros: pomodoros,
	}
	err = repo.UpsertTodo(todo)
	assert.Nil(t, err)

      // Retreive the todo
	todo, err = repo.GetTodoByID(1)
	assert.Nil(t, err)
	assert.Equal(t, "Test", todo.Name)
	assert.Equal(t, pomodoros[0].StartTime.UTC(), todo.Pomodoros[0].StartTime.UTC())

	// Update the todo
	todo.Name = "Test Updated"
	err = repo.UpsertTodo(todo)
	assert.Nil(t, err)

	// Retreive the updated todo
	todo, err = repo.GetTodoByID(1)
	assert.Nil(t, err)
	assert.Equal(t, "Test Updated", todo.Name)
	assert.Equal(t, pomodoros[0].StartTime.UTC(), todo.Pomodoros[0].StartTime.UTC())
}
