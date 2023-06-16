package com.eventsharing.EventSharing;

import com.eventsharing.EventSharing.model.Event;
import com.eventsharing.EventSharing.repository.EventsRepository;
import com.eventsharing.EventSharing.repository.UsersRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.text.SimpleDateFormat;
import java.util.Date;

@SpringBootApplication
public class EventSharingApplication {

	public static void main(String[] args) {
		SpringApplication.run(EventSharingApplication.class, args);
	}


}
