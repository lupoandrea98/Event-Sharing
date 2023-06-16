package com.eventsharing.EventSharing.repository;

import com.eventsharing.EventSharing.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UsersRepository extends JpaRepository<User, Long> {

    //Oltre le query base offerte dall'interfaccia di jpa, posso scrivere
    //delle custom query per titolo oppure specificando con uno pseudo SQL
    //l'operazione da eseguire

    //Nella query non mi riferisco alle tabelle del db ma a classi e parametri di esse
//    @Query("SELECT u FROM User u WHERE u.username = ?1 AND u.password = ?2")
//    Optional<User> loadByUsernameAndPw(String username, String pw);
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Optional<User> findById(String id);

}
