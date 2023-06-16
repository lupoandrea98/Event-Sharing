package com.eventsharing.EventSharing.model;

import jakarta.persistence.*;
import org.hibernate.annotations.Cascade;
import java.util.Set;

@Entity
@Table(name = "users")
public class User {

    @Id
    //Token univoco generato tramite FIREBASE alla prima registrazione
    @Column(nullable = false)
    private String id;
    @Column(
        unique = true
    )
    private String username;

    private String email;

    @Lob
    private String image;
    @OneToMany(
            mappedBy = "owner",
            fetch = FetchType.LAZY,
            cascade = CascadeType.REMOVE,
            orphanRemoval = true        //Opzione che specifica che gli evenenti creati dall'utente devono essere rimossi nel momento in cui il loro proprieatrio viene eliminato
    )
    private Set<Event> created;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private Set<Partecipation> partecipations;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private Set<Favourite> favourites;

    public User() {
    }

    public User(String id, String username, String email, String image) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.image = image;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public Set<Event> getCreated() {
        return created;
    }

    public void setCreated(Set<Event> created) {
        this.created = created;
    }

    public Set<Partecipation> getPartecipations() {
        return partecipations;
    }

    public void setPartecipations(Set<Partecipation> partecipations) {
        this.partecipations = partecipations;
    }

    public Set<Favourite> getFavourites() {
        return favourites;
    }

    public void setFavourites(Set<Favourite> favourites) {
        this.favourites = favourites;
    }

    @Override
    public String toString() {
        String toString = "User{" +
                "id='" + id + '\'' +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                '}';
        return toString;
    }
}
