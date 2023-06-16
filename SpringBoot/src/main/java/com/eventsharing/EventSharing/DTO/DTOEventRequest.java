package com.eventsharing.EventSharing.DTO;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class DTOEventRequest {
    private String id;
    private String title;
    private Double latitude;
    private Double longitude;
    private String address;
    private LocalDate date;
    private String tag;
    private String description;
    private String image;
    private String owner;
    private String qrCode;
    private int max_partecipnt;
    private String externalLink;

    public DTOEventRequest(String title, Double latitude, Double longitude, String address, String date, String tag, String description, String image, String owner, Integer max_partecipnt, String externalLink) {
        this.title = title;
        this.latitude = latitude;
        this.longitude = longitude;
        if (address.equals("")) {
            this.address = "Online";
        }else {
            this.address = address;
        }
        DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        this.date = LocalDate.parse(date, df);
        this.tag = tag;
        this.description = description;
        this.image = image;
        this.owner = owner;
        this.max_partecipnt = max_partecipnt;
        this.externalLink = externalLink;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public String getTag() {
        return tag;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getOwner() {
        return owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public String getQrCode() {
        return qrCode;
    }

    public void setQrCode(String qrCode) {
        this.qrCode = qrCode;
    }

    public int getMax_partecipnt() {
        return max_partecipnt;
    }

    public void setMax_partecipnt(int max_partecipnt) {
        this.max_partecipnt = max_partecipnt;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getExternalLink() {
        return externalLink;
    }

    public void setExternalLink(String externalLink) {
        this.externalLink = externalLink;
    }
}
