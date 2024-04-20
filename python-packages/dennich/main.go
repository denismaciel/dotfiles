package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"time"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// Define Todo struct mapping to the todos table
type Todo struct {
	ID          uint      `gorm:"primaryKey"`
	Name        string    `gorm:"not null"`
	Type        string    `gorm:"size:5;not null"`
	CreatedAt   time.Time `gorm:"not null"`
	CompletedAt *time.Time
	Order       time.Time `gorm:"not null"`
	UpdatedAt   time.Time `gorm:"not null"`
	// Tags        json.RawMessage // Use json.RawMessage for JSON types
	Pomodoros []Pomodoro `gorm:"foreignKey:TodoID"` // Define the relationship
}

// Define Pomodoro struct mapping to the pomodoros table
type Pomodoro struct {
	ID        uint      `gorm:"primaryKey"`
	TodoID    uint      `gorm:"not null"`
	StartTime time.Time `gorm:"not null"`
	EndTime   *time.Time
	Duration  float64 `gorm:"not null"`
	Todo      Todo    `gorm:"foreignKey:TodoID"` // Define the relationship
}

func client() {
	// Open a DB connection
	db, err := gorm.Open(sqlite.Open("todo-clone.db"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	// AutoMigrate the schema
	db.AutoMigrate(&Todo{}, &Pomodoro{})
	repo := &repo{db: db}

	todos, err := repo.GetTodos(Todo{})
	if err != nil {
		panic(err)
	}

	for _, todo := range todos {
		done := "NOT_DONE"
		if todo.CompletedAt != nil {
			done = "DONE"
		}
		println(todo.Name, done)
	}
}

type repo struct {
	db *gorm.DB
}

func (r *repo) GetTodos(filter Todo) ([]Todo, error) {
	var todos []Todo
	err := r.db.Preload("Pomodoros").Where(filter).Find(&todos).Error
	return todos, err
}

func (r *repo) GetTodoByID(id uint) (Todo, error) {
	var todo Todo
	err := r.db.Preload("Pomodoros").First(&todo, id).Error
	return todo, err
}

func (r *repo) UpsertTodo(todo Todo) error {
	return r.db.Save(&todo).Error
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("No argument provided")
		return
	}

	// Retrieve the first argument
	arg := os.Args[1]

	// Call different functions based on the argument
	switch arg {
	case "server":
		runServer()
	case "client":
		runClient()
	default:
		fmt.Printf("Unknown argument: %s\n", arg)
	}
}

func runServer(

) {
	listenAddr := "0.0.0.0:12350"
	listener, err := net.Listen("tcp", listenAddr)
	if err != nil {
		log.Fatalf("Failed to listen on %s: %v", listenAddr, err)
	}
	defer listener.Close()
	log.Printf("Listening on %s", listenAddr)

	runningPomodoro := NewServerState()
	runningPomodoro.runningPomodoro = &Pomodoro{
		StartTime: time.Now(),
		Duration:  25,
		Todo: Todo{
			Name: "Write code",
		},
	}

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("Failed to accept connection: %v", err)
			continue
		}

		go handleConnection(conn, runningPomodoro)
	}
}
